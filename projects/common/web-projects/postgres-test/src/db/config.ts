import {DataSource} from 'typeorm';
import {PostgresConnectionOptions} from 'typeorm/driver/postgres/PostgresConnectionOptions';
import {TlsOptions} from 'node:tls';
import {TypeORMLogger} from './typeormLogger';

const env = process.env.NODE_ENV || 'development';

const user = process.env.PGUSER || 'postgres';
const pass = process.env.PGPASSWORD || 'postgres';
const host = process.env.PGHOST || 'localhost';
const port = parseInt(process.env.PGPORT || '5432');
const db = process.env.PGDATABASE || 'db';
const connectionString = `postgresql://${user}:${pass}@${host}:${port}/${db}`;

const serverCA = process.env.PGHOST_CA_CERT;
const clientKey = process.env.PGCLIENT_KEY;
const clientCert = process.env.PGCLIENT_CERT;

const options: PostgresConnectionOptions = {
  type: 'postgres',
  url: connectionString,
  logging: true,
  synchronize: env === 'development' ? true : false,
  migrationsRun: false,
  entities: ['./build/entities/**/*.js'],
  migrations: ['./build/db/migrations/**/*.js'],
  logger: new TypeORMLogger(),
  ssl: serverCA
    ? ({
        rejectUnauthorized: true, // reject encrypted connections that don't stem from the server ca
        requestCert: true,
        ca: serverCA,
        key: clientKey,
        cert: clientCert,
        // cloud sql host names end up as "localhost" and don't match anything on the server cert
        // actually, I think this is a postgres connector problem when a servername isn't entered, but I digress...
        // the correct server for the cert ends up looking completely gnarly and can't be figured out
        // like "1-78087e38-3275-4759-be59-77ada401a0a3.us-central1.sql.goog"
        // so just ignore verifying the server name
        // we are already verifying the cert chain so we should be good even if the server changes
        // ALSO, this function doesn't sit on the TlsOptions interface but it is passed to the connection anyway
        // so have to cast this object as TlsOptions
        checkServerIdentity: () => undefined,
      } as TlsOptions)
    : false,
};

export const db_config = new DataSource(options);
