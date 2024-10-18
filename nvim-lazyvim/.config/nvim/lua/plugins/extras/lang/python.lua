return {
  "nvim-neotest/neotest",
  opts = {
    adapters = {
      ["neotest-python"] = {
        runner = "pytest",
      },
    },
  },
}
