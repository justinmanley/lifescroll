module.exports = {
    transform: {
        "^.+\\.(ts|tsx)$": "ts-jest",
    },
    runner: "jest-electron/runner",
    testEnvironment: "jest-electron/environment",
};
