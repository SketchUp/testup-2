// Polyfill definition - copied from:
// https://github.com/Salasar/TypeScript/blob/df5e176e179aee42a2f67517aafbecf88b0d27b4/src/lib/es2015.core.d.ts
interface Array<T> {
  findIndex(predicate: (value: T, index: number, obj: Array<T>) => boolean, thisArg?: any): number;
}
