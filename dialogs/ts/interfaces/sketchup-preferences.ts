import { SketchUp } from './sketchup';

export interface SketchUpPreferences extends SketchUp {
  addPath(): void;
  editPath(path: string, index: number): void;
  save(): void;
  cancel(): void;
}
