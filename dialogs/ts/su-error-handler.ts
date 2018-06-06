import Vue from "vue";

function sendErrorToSketchUp(message: string, backtrace: any, error?: Error): void {
  let data = {
    'message' : message,
    'backtrace' : backtrace,
    'user-agent': navigator.userAgent,
    'document-mode': document.documentMode
  };
  sketchup.js_error(data);
  console.error(data.message);
  console.error(error);
}

function vueErrorHandler(error: Error, vm: Vue, info: string): void {
  const message = `Vue Error (${info}): ${error.message}`;
  sendErrorToSketchUp(message, error.stack, error);
}

// TODO(thomthom): Look into also hooking up warnHandler.
// https://vuejs.org/v2/api/#warnHandler

function globalErrorHandler(event: Event | string, source?: string, line?: number, column?: number, error?: Error): void {
  try
  {
    // Not all browsers pass along the error object. Without that it's not
    // possible to get full backtrace.
    // http://blog.bugsnag.com/js-stacktraces
    var backtrace = [];
    if (error && error.stack)
    {
      backtrace = String(error.stack).split("\n");
    }
    else
    {
      backtrace = [source + ':' + line + ':' + column];
    }
    sendErrorToSketchUp(event.toString(), backtrace, error);
  }
  catch (error)
  {
    debugger;
    throw error;
  }
};

export { globalErrorHandler, vueErrorHandler };
