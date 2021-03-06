describe "Myna.init", ->
  it "should create a client", ->
    client = Myna.init
      apiKey:   "092c90f6-a8f2-11e2-a2b9-7c6d628b25f7"
      apiRoot:  testApiRoot
      experiments: [
        {
          uuid:     "aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa"
          id:       "a"
          settings: "myna.web.sticky": false
          variants: [
            { id: variant1, weight: 0.4 }
            { id: variant2, weight: 0.6 }
          ]
        }
        {
          uuid:     "bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbbb"
          id:       "b"
          settings: "myna.web.sticky": true
          variants: [
            { id: foo, weight: 0.2 }
            { id: bar, weight: 0.8 }
          ]
        }
      ]

    expect(client).toBeInstanceOf(Myna.Client)

    expect(client.experiments.a).toBeInstanceOf(Myna.Experiment)
    expect(client.experiments.b).toBeInstanceOf(Myna.Experiment)

    expect(client.experiments.a.variants.variant1).toBeInstanceOf(Myna.Variant)
    expect(client.experiments.a.variants.variant2).toBeInstanceOf(Myna.Variant)
    expect(client.experiments.b.variants.foo).toBeInstanceOf(Myna.Variant)
    expect(client.experiments.b.variants.bar).toBeInstanceOf(Myna.Variant)

describe "Myna.initRemote", ->
  it "should create a client", ->
    client = null

    runs ->
      Myna.initRemote
        apiKey:  "092c90f6-a8f2-11e2-a2b9-7c6d628b25f7"
        apiRoot: testApiRoot
        success: (c) -> client = c

    waitsFor -> client

    runs ->
      expect(client).toBeInstanceOf(Myna.Client)

      for id, expt of client.experiments
        Myna.log(" - ", id, expt)

      expect(client.experiments.test).toBeInstanceOf(Myna.Experiment)

      expect(client.experiments.test.variants.variant1).toBeInstanceOf(Myna.Variant)
      expect(client.experiments.test.variants.variant2).toBeInstanceOf(Myna.Variant)