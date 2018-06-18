import { PreferencesConfig } from "./preferences-config";
import { SketchUp } from './sketchup';

export interface SketchUpPreferences extends SketchUp {
  addPath(): void;
  editPath(path: string, index: number): void;
  save(config: PreferencesConfig): void;
  cancel(): void;
}
