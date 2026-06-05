module.exports = {
  preset: "ts-jest",
  testEnvironment: "node",
  roots: ["<rootDir>/src"],
  testMatch: ["**/*.test.ts"],
  reporters: ["default", ["jest-junit", { outputDirectory: "test-results" }]],
};
