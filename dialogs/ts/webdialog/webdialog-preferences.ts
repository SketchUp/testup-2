import { PreferencesConfig } from "../interfaces/preferences-config";
import { SketchUpPreferences } from '../interfaces/sketchup-preferences'
import { WebDialogShim } from '../webdialog/webdialog-shim'

export class PreferencesWebDialogShim extends WebDialogShim implements SketchUpPreferences {
  addPath(): void
  {
    this.sketchup('addPath');
  }
  editPath(path: string, index: number): void
  {
    this.sketchup('runTests', [path, index]);
  }
  save(config: PreferencesConfig): void
  {
    this.sketchup('save', [config]);
  }
  cancel(): void
  {
    this.sketchup('cancel');
  }
}
