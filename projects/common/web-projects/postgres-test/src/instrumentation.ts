import {NodeSDK} from '@opentelemetry/sdk-node';
import {ConsoleSpanExporter} from '@opentelemetry/sdk-trace-node';
import {BatchSpanProcessor, SimpleSpanProcessor} from '@opentelemetry/sdk-trace-base';
import {getNodeAutoInstrumentations} from '@opentelemetry/auto-instrumentations-node';
import {GracefulShutdown} from 'graceful-sd';
import {TraceExporter as GoogleSpanExporter} from '@google-cloud/opentelemetry-cloud-trace-exporter';
import {PinoInstrumentation} from '@opentelemetry/instrumentation-pino';
import {pino} from 'pino';

// turn on instrumentation if the environment variable is set
const ENABLE_INSTRUMENTATION = process.env.ENABLE_INSTRUMENTATION || 'false';
if (ENABLE_INSTRUMENTATION.toLowerCase() === 'true') {
  const traceExporter = getSpanExporter();
  // const spanProcessor = new BatchSpanProcessor(traceExporter);
  const spanProcessor = new SimpleSpanProcessor(traceExporter);
  const opentelemetrySDK = new NodeSDK({
    traceExporter: traceExporter,
    spanProcessor: spanProcessor,
    instrumentations: [
      getNodeAutoInstrumentations({
        '@opentelemetry/instrumentation-fs': {
          // the fs instrumentation sees the project loading
          // modules (imports and whatnot) as fs reads
          // so ends up logging TONS of them during startup...
          // disable this for now
          // there seems to be a way to turn it on after
          // startup by using a createHook, but thats for later...
          enabled: false,
        },
      }),
      new PinoInstrumentation(),
    ],
  });

  opentelemetrySDK.start();
  GracefulShutdown.Instance.registerAfterServerShutdownCallback(async () => {
    // can't use the regular logger class because it resolves before
    // the opentelemetry instrumentations can modify the implementation
    // which breaks the trace information for the rest of the app...
    // so create our own logger for just this instance
    const log = pino().child({module: 'Instrumentation'});

    log.info('Stopping opentelemetry...');
    await opentelemetrySDK.shutdown();
    log.info('Opentelemetry stopped.');
  });
}

/**
 * Create a span exporter based on the configured environment variable.
 * Defaults to creating a ConsoleSpanExporter.
 *
 * Env variable OPENTELEMETRY_SPAN_EXPORTER options:
 * - gcp = GoogleSpanExporter
 *
 * @returns a SpanExporter based on the environment variable
 */
function getSpanExporter() {
  // create a logger (same notes as above)
  const log = pino().child({module: 'Instrumentation'});

  const DESIRED_EXPORTER = process.env.OPENTELEMETRY_SPAN_EXPORTER || '';
  if (DESIRED_EXPORTER.toLowerCase() === 'gcp') {
    log.info('Using GoogleSpanExporter as desired OpenTelemetry span exporter...');
    return new GoogleSpanExporter();
  } else {
    log.info('Using ConsoleSpanExporter as desired OpenTelemetry span exporter...');
    return new ConsoleSpanExporter();
  }
}
