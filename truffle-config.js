module.exports = {
  networks: {
    development: {
      host: "127.0.0.1",
      port: 9545,
      network_id: "*"
    },
    dashboard: {},
    loc_test_test: {
      network_id: "*",
      port: 8547,
      host: "127.0.0.1"
    },
    loc_development_development: {
      network_id: "*",
      port: 8546,
      host: "127.0.0.1"
    }
  },
  compilers: {
    solc: {
      version: "0.8.13"
    }
  },
  db: {
    enabled: false,
    host: "127.0.0.1"
  }
};
