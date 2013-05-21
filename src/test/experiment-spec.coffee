window.expt = new Myna.Experiment
  uuid:     "uuid"
  id:       "id"
  apiKey:   "key"
  settings: "myna.sticky": true
  variants:
    a: { settings: { buttons: "red"   }, weight: 0.2 }
    b: { settings: { buttons: "green" }, weight: 0.4 }
    c: { settings: { buttons: "blue"  }, weight: 0.6 }

describe "Myna.Experiment.constructor", ->
  it "should accept custom options", ->
    expect(expt.uuid).toEqual("uuid")
    expect(expt.id).toEqual("id")
    expect(expt.apiKey).toequal("key")
    expect(expt.settings.data).toEqual(sticky: true)
    expect(for key, value of expt.variants then key).toEqual(["a", "b", "c"])
    expect(for key, value of expt.variants then value.id).toEqual(["a", "b", "c"])
    expect(for key, value of expt.variants then value.settings.data).toEqual([
      { buttons: "red"   }
      { buttons: "green" }
      { buttons: "blue"  }
    ])
    expect(for key, value of expt.variants then value.weight).toEqual([ 0.2, 0.4, 0.6 ])

  it "should succeed if no settings or variants are provided", ->
    actual = new Myna.Experiment(uuid: "uuid", id: "id", apiKey: "key")
    expect(actual.settings.data).toEqual({})
    expect(actual.variants).toEqual({})

  it "should fail if no uuid is provided", ->
    expect(-> new Myna.Experiment(id: "id", apiKey: "key")).toThrow()

  it "should fail if no id is provided", ->
    expect(-> new Myna.Experiment(uuid: "uuid", apiKey: "key")).toThrow()

  it "should fail if no apiKey is provided", ->
    expect(-> new Myna.Experiment(uuid: "uuid", id: "id")).toThrow()

describe "Myna.Experiment.sticky", ->
  it "should be derived from the 'myna.sticky' setting", ->
    expect(new Myna.Experiment(uuid: "uuid", id: "id", apiKey: "key", settings: "myna.sticky": true).sticky()).toEqual(true)
    expect(new Myna.Experiment(uuid: "uuid", id: "id", apiKey: "key", settings: "myna.sticky": false).sticky()).toEqual(false)

  it "should default to true", ->
    expect(new Myna.Experiment(uuid: "uuid", id: "id", apiKey: "key").sticky()).toEqual(true)

describe "Myna.Experiment.totalWeight", ->
  it "should return the sum of the variants' weights, even if they don't total 1.0", ->
    expect(expt.totalWeight()).toBeCloseTo(1.2, 0.001)

describe "Myna.Experiment.randomVariant", ->
  it "should return ... er ... random variants", ->
    ids = []
    for i in [1..100]
      actual = expt.randomVariant()
      expect(actual).toBeInstanceOf(Myna.Variant)
      ids.push(actual.id)
    expect(ids).toContain("a")
    expect(ids).toContain("b")
    expect(ids).toContain("c")

  it "should skew in favour of the most popular variants", ->
    expt.variants.a.weight = 0.0
    expt.variants.c.weight = 0.0
    ids = []
    for i in [1..100]
      ids.push(expt.randomVariant().id)
    expect(ids).not.toContain("a")
    expect(ids).toContain("b")
    expect(ids).not.toContain("c")

for localStorageEnabled in [false, true] # end up resetting it to true
  Myna.cache.localStorageEnabled = localStorageEnabled

  localStorageStatus =
    "localStorage" +
    (if Myna.cache.localStorageSupported then ' supported,' else ' unsupported,') +
    (if Myna.cache.localStorageEnabled then ' enabled' else ' disabled')

  describe "Myna.Experiment.{load,save,clear}LastSuggestion (#{localStorageStatus})", ->
    it "should load nothing if nothing has been saved", ->
      expt.clearLastSuggestion()
      expect(expt.loadLastSuggestion()).toEqual(null)

    it "should load the last saved suggestion", ->
      expt.saveLastSuggestion(expt.variants.a)
      expect(expt.loadLastSuggestion()).toBe(expt.variants.a)

      expt.saveLastSuggestion(expt.variants.b)
      expect(expt.loadLastSuggestion()).toBe(expt.variants.b)

    it "should not interfere with other experiments", ->
      expt2 = new Myna.Experiment
        uuid:   "bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbbb"
        id:     "id2"
        apiKey: "key"
      expt.saveLastSuggestion(expt.variants.a)
      expect(expt2.loadLastSuggestion()).toEqual(null)

  describe "Myna.Experiment.{load,save,clear}StickySuggestion (#{localStorageStatus})", ->
    it "should load nothing if nothing has been saved", ->
      expt.clearStickySuggestion()
      expect(expt.loadStickySuggestion()).toEqual(null)

    it "should load the last saved suggestion", ->
      expt.saveStickySuggestion(expt.variants.a)
      expect(expt.loadStickySuggestion()).toBe(expt.variants.a)

      expt.saveStickySuggestion(expt.variants.b)
      expect(expt.loadStickySuggestion()).toBe(expt.variants.b)

    it "should not interfere with other experiments", ->
      expt2 = new Myna.Experiment
        uuid: "bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbbb"
        id: "id2"
      expt.saveStickySuggestion(expt.variants.a)
      expect(expt2.loadStickySuggestion()).toEqual(null)

    it "should not interfere with the last suggestion", ->
      expt.saveLastSuggestion(expt.variants.a)
      expt.saveStickySuggestion(expt.variants.b)
      expect(expt.loadLastSuggestion()).toBe(expt.variants.a)
      expect(expt.loadStickySuggestion()).toBe(expt.variants.b)

  describe "Myna.Experiment.{load,save,clear}StickyReward (#{localStorageStatus})", ->
    it "should load nothing if nothing has been saved", ->
      expt.clearStickyReward()
      expect(expt.loadStickyReward()).toEqual(null)

    it "should load the last saved suggestion", ->
      expt.saveStickyReward(expt.variants.a)
      expect(expt.loadStickyReward()).toBe(expt.variants.a)

      expt.saveStickyReward(expt.variants.b)
      expect(expt.loadStickyReward()).toBe(expt.variants.b)

    it "should not interfere with other experiments", ->
      expt2 = new Myna.Experiment
        uuid: "bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbbb"
        id: "id2"
      expt.saveStickyReward(expt.variants.a)
      expect(expt2.loadStickyReward()).toEqual(null)

    it "should not interfere with the last or sticky suggestion", ->
      expt.saveLastSuggestion(expt.variants.a)
      expt.saveStickySuggestion(expt.variants.b)
      expt.saveStickyReward(expt.variants.c)
      expect(expt.loadLastSuggestion()).toBe(expt.variants.a)
      expect(expt.loadStickySuggestion()).toBe(expt.variants.b)
      expect(expt.loadStickyReward()).toBe(expt.variants.c)
