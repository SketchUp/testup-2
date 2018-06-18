export interface EditorConfig {
  executable: string,
  arguments: string,
}

export interface PreferencesConfig {
  test_suite_paths: Array<string>,
  editor: EditorConfig,
}
