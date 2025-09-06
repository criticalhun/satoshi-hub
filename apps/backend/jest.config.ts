export default {
  moduleFileExtensions: ['js', 'json', 'ts'],
  rootDir: './',
  testRegex: 'src/.*\\.spec\\.ts$',
  transform: {
    '^.+\\.(t|j)s$': 'ts-jest',
  },
  collectCoverageFrom: [
    'src/**/*.(t|j)s',
    '!src/**/*.spec.ts',
    '!src/main.ts',
    '!src/**/*.interface.ts',
  ],
  coverageDirectory: './coverage',
  testEnvironment: 'node',
  moduleNameMapper: {
    '^src/(.*)$': '<rootDir>/src/$1',
    '^@satoshi-hub/sdk$': '<rootDir>/../../packages/sdk/src/index.ts',
  },
  transformIgnorePatterns: [
    '/node_modules/',
    '/dist/',
    '/packages/sdk/dist/',
  ],
  coveragePathIgnorePatterns: [
    '/node_modules/',
    '/dist/',
    '.interface.ts$',
    '.dto.ts$',
  ],
};
