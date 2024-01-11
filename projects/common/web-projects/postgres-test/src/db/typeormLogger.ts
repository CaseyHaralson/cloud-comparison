import {AbstractLogger, LogLevel, LogMessage, QueryRunner} from 'typeorm';
import {getLogger} from '../logger';

export class TypeORMLogger extends AbstractLogger {
  private logger = getLogger('TypeORMLogger');

  logQuery(query: string, parameters?: any[], queryRunner?: QueryRunner) {
    this.writeLog('query', {
      type: 'query',
      message: query,
      parameters: parameters,
    });
  }

  logQueryError(
    error: string,
    query: string,
    parameters?: any[],
    queryRunner?: QueryRunner
  ) {
    this.writeLog('query', {
      type: 'query-error',
      message: `error: ${error}; query: ${query}`,
      parameters: parameters,
    });
  }

  logQuerySlow(
    time: number,
    query: string,
    parameters?: any[],
    queryRunner?: QueryRunner
  ) {
    this.writeLog('query', {
      type: 'query-slow',
      message: `time: ${time}; query: ${query}`,
      parameters: parameters,
    });
  }

  logSchemaBuild(message: string, queryRunner?: QueryRunner) {
    this.writeLog('schema', {type: 'schema-build', message: message});
  }

  logMigration(message: string, queryRunner?: QueryRunner) {
    this.writeLog('migration', {type: 'migration', message: message});
  }

  log(
    level: 'log' | 'info' | 'warn',
    message: any,
    queryRunner?: QueryRunner | undefined
  ): void {
    this.writeLog(level, {type: level, message: message});
  }

  protected writeLog(
    level: LogLevel,
    logMessage: LogMessage | LogMessage[],
    queryRunner?: QueryRunner
  ) {
    const messages = this.prepareLogMessages(logMessage, {highlightSql: false});

    for (let message of messages) {
      switch (message.type ?? level) {
        case 'log':
        case 'schema-build':
        case 'migration':
          this.logger.debug(this.buildMessageString(message));
          break;

        case 'info':
        case 'query':
          this.logger.info(this.buildMessageString(message));
          break;

        case 'warn':
        case 'query-slow':
          this.logger.warn(this.buildMessageString(message));
          break;

        case 'error':
        case 'query-error':
          this.logger.error(this.buildMessageString(message));
          break;
      }
    }
  }

  private buildMessageString(message: LogMessage) {
    // start with the message prefix
    let s = message.prefix || '';

    // then add the message
    if (s.length > 0) s += ' - ' + message.message;
    else s += message.message;

    // then add any parameters
    if (message.parameters)
      s += '; parameters: ' + JSON.stringify(message.parameters);

    return s;
  }
}
