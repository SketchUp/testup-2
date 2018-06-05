function sendErrorToSketchUp(data) {
  sketchup.js_error(data);
  console.error(data.message);
  console.error(error);
}

function vueErrorHandler(error, vm, info) {
  let data = {
    'message' : `Vue Error (${info}): ${error.message}`,
    'backtrace' : error.backtrace,
    'user-agent': navigator.userAgent,
    'document-mode': document.documentMode
  };
  sendErrorToSketchUp(data)
}

// TODO(thomthom): Look into also hooking up warnHandler.
// https://vuejs.org/v2/api/#warnHandler

function globalErrorHandler(message, file, line, column, error) {
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
      backtrace = [file + ':' + line + ':' + column];
    }
    var data = {
      'message' : message,
      'backtrace' : backtrace,
      'user-agent': navigator.userAgent,
      'document-mode': document.documentMode
    };
    sendErrorToSketchUp(data)
  }
  catch (error)
  {
    debugger;
    throw error;
  }
};

export { globalErrorHandler, vueErrorHandler };
