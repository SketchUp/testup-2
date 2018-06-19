export interface SketchUp {
  js_error(error_data: any): void;
  open_url(url: string): void;
  ready(): void;
}
