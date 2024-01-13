import express, {NextFunction, Request, Response} from 'express';
import {GracefulShutdown} from 'graceful-sd';
import 'reflect-metadata';
import {AppDataSource, waitForDatabaseConnection} from './db/appDataSource';
import {Photo} from './entities/photo';
import {getLogger} from './logger';

const log = getLogger('App');

// set up the express server
const app = express();
const port = process.env.PORT || 3000;

async function catchAndPassErrors<T>(
  next: NextFunction,
  func: () => Promise<T>
) {
  try {
    return await func();
  } catch (e) {
    log.error(e);
    next(e);
  }
}

app.get('/', (req, res) => {
  res.send('Hello, World!');
});

app.get('/photos', async (req, res, next) => {
  catchAndPassErrors(next, async () => {
    const photos = await AppDataSource.query(
      `
      select * 
      from photo 
      order by views desc 
      limit 100
      `
    );
    res.send(photos);
  });
});

app.get('/photos/update-views', async (req, res, next) => {
  catchAndPassErrors(next, async () => {
    // const id = getRandomPhotoId();
    const id = 1;
    await updatePhotoViews(id);
    res.send(`photo updated: ${id}`);
  });
});
function getRandomPhotoId(): number {
  const id = Math.floor(Math.random() * 1000);
  if (id != 0) return id;
  else return getRandomPhotoId();
}
async function updatePhotoViews(id: number) {
  await AppDataSource.transaction(async (transaction) => {
    const photos = (await transaction.query(
      `
        select * 
        from photo 
        where id = $1
        for update
        `,
      [id]
    )) as Photo[];
    await transaction.query(
      `
        update photo
        set views = $1
        where id = $2
        `,
      [photos[0].views + 10, photos[0].id]
    );
    // throw new Error('testing transaction');
  });
}

app.get('/ready', async (req, res, next) => {
  catchAndPassErrors(next, async () => {
    await waitForDatabaseConnection();
    res.send('ready!');
  });
});

const server = app.listen(port, () => {
  log.info(`App listening on port ${port}`);
});
GracefulShutdown.Instance.registerServer(server);
