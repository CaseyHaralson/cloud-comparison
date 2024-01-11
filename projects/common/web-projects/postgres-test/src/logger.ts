import pino from 'pino';

let logger = pino();
function getLogger(module: string) {
  return logger.child({module: module});
}

export {getLogger};
