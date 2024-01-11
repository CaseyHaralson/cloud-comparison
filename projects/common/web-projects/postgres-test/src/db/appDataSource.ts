import {GracefulShutdown} from 'graceful-sd';
import {db_config} from './config';
import {getLogger} from '../logger';

const log = getLogger('AppDataSource');

log.info(`initializing connection to database...`);
db_config
  .initialize()
  .then(() => {
    log.info(`database connection initialized`);
  })
  .catch((e) => log.info(`database connection initialization error: ${e}`));
GracefulShutdown.Instance.registerAfterServerShutdownCallback(async () => {
  log.info('closing database connections...');
  if (db_config.isInitialized) await db_config.destroy();
  log.info('database connections closed');
});

export {db_config as AppDataSource};

function sleep(ms: number) {
  return new Promise((resolve) => setTimeout(resolve, ms));
}
export async function waitForDatabaseConnection() {
  let i = 0;
  const waitMs = 10;
  while (!db_config.isInitialized && i < 10) {
    await sleep(waitMs);
    i++;
  }
  if (db_config.isInitialized) return true;
  else
    throw Error(
      `The database connection wasn't ready in ${i * waitMs} milliseconds`
    );
}
