import { SketchUp } from "./interfaces/sketchup";
declare const sketchup: SketchUp;


/* Ensure links are opened in the default browser. This ensures that the
 * WebDialog doesn't replace the content with the target URL.
 */
export function redirect_links(): void {
  document.addEventListener('click', (event: Event) => {
    let element = event.target as HTMLElement;
    if (element.nodeName == 'A') {
      let anchor = element as HTMLAnchorElement;
      if (anchor.href) {
        sketchup.open_url(anchor.href);
        event.preventDefault();
        return false;
      }
    }
    return true;
  });
}


/* Disables text selection on elements other than input type elements where
 * it makes sense to allow selections. This mimics native windows.
 */
export function disable_select(): void {
  ['mousedown', 'selectstart'].forEach(function(eventName: string){
    window.addEventListener(eventName, selectHandler, false);
  });
}

function selectHandler(event: Event) : void {
  console.log('selectHandler', event, event.target);
  console.log('> isText:', event.target instanceof Text);
  let element : HTMLElement | null = null;
  if (event.target instanceof Text) {
    let text = event.target as Text;
    element = text.parentElement;
  }
  if (event.target instanceof HTMLElement) {
    element = event.target;
  }
  if (element) {
    if (element.closest('.su-selectable')) {
      return;
    }
    if (['INPUT', 'TEXTAREA', 'SELECT', 'OPTION'].includes(element.nodeName)) {
      return;
    }
  }
  event.preventDefault();
}


/* Disables the context menu with the exception for textboxes in order to
 * mimic native windows.
 */
export function disable_context_menu(): void {
  document.addEventListener('contextmenu', function(event: MouseEvent) {
    // Allow Ctrl + Shift to enable the native context menu as a backdoor for
    // debugging.
    if (event.ctrlKey && event.shiftKey) {
      return true;
    }
    // Allow context menu for input fields.
    let element = event.target as HTMLElement;
    if (element.nodeName == 'TEXTAREA') {
      return true;
    }
    if (element.nodeName == 'INPUT') {
      let input = element as HTMLInputElement;
      if (input.type == 'text') {
        return true;
      }
    }
    // Prevent it for anything else.
    event.preventDefault();
    return false;
  });
}
