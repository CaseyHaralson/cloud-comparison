import {setSeederFactory} from 'typeorm-extension';
import {Photo} from '../../entities/photo';

export default setSeederFactory(Photo, (faker) => {
  const photo = new Photo();
  photo.name = faker.word.words({count: {min: 1, max: 3}});
  photo.description = faker.word.words(20);
  photo.filename = faker.image.url();
  photo.views = faker.number.int({max: 10000});
  photo.isPublished = faker.number.int({min: 0, max: 1}) === 1 ? true : false;
  return photo;
});
