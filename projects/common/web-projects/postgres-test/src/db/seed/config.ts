import {SeederOptions} from 'typeorm-extension';
import {db_config} from '../config';
import {DataSource, DataSourceOptions} from 'typeorm';

const options: DataSourceOptions & SeederOptions = {
  ...db_config.options,
  seeds: ['./build/db/seed/**/*.seeder.js'],
  factories: ['./build/db/seed/**/*.factory.js'],
};

export const dataSource = new DataSource(options);
