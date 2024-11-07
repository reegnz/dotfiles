return {
  "nvim-neotest/neotest",
  dependencies = "nvim-neotest/neotest-jest",
  opts = {
    adapters = {
      ["neotest-jest"] = {
        jestCommand = "npm run jest --",
        jestConfigFile = "jest.config.ts",
        env = { CI = true },
        cwd = function(_)
          return vim.fn.getcwd()
        end,
      },
    },
  },
}
