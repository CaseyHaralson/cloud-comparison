import {DataSource} from 'typeorm';
import {Seeder, SeederFactoryManager} from 'typeorm-extension';
import {Photo} from '../../entities/photo';

export default class PhotoSeeder implements Seeder {
  public async run(
    dataSource: DataSource,
    factoryManager: SeederFactoryManager
  ): Promise<any> {
    // const repo = dataSource.getRepository(Photo);

    const photoFactory = await factoryManager.get(Photo);
    await photoFactory.saveMany(1000);
  }
}
