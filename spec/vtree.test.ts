import Configuration from '../src/configuration'
import Vtree from '../src/vtree'
import Launcher from '../src/vtree_src/launcher'

describe('Vtree', () => {
  let initialLauncher: Launcher

  beforeAll(() => {
    initialLauncher = Vtree._launcher

    Vtree._launcher = new Launcher()
  })

  afterAll(() => {
    Vtree._launcher = initialLauncher
  })

  describe('.initNodes', () => it("calls Launcher's launch and createViewsTree functions", () => {
    jest.spyOn(Vtree.launcher, 'launch')
    jest.spyOn(Vtree.launcher, 'createViewsTree')

    Vtree.initNodes()

    expect(Vtree.launcher.launch).toHaveBeenCalledOnce()
    expect(Vtree.launcher.createViewsTree).toHaveBeenCalledOnce()
  }))

  describe('.getInitCallbacks', () => {
    it('returns empty list by default', () => {
      expect(Vtree.getInitCallbacks()).toEqual([])
    })
  })

  describe('.onNodeInit', () => {
    it('adds initialization callback to onInit callbacks', () => {
      const callback = () => {}
      const secondCallback = () => {}

      Vtree.onNodeInit(callback)
      expect(Vtree.getInitCallbacks()).toEqual([callback])

      Vtree.onNodeInit(secondCallback)
      expect(Vtree.getInitCallbacks()).toEqual([callback, secondCallback])
    })
  })

  describe('.getUnloadCallbacks', () => {
    it('returns empty list by default', () => {
      expect(Vtree.getUnloadCallbacks()).toEqual([])
    })
  })

  describe('.onNodeUnload', () => {
    it('adds unload callback to onUnload callbacks', () => {
      const callback = () => {}
      const secondCallback = () => {}
      Vtree.onNodeUnload(callback)
      expect(Vtree.getUnloadCallbacks()).toEqual([callback])

      Vtree.onNodeUnload(secondCallback)
      expect(Vtree.getUnloadCallbacks()).toEqual([callback, secondCallback])
    })
  })

  describe('.configure', () => {
    it('extends configuration data with provided options', () => {
      const config = new Configuration
      Vtree._config = config

      Vtree.configure({
        viewSelector: '.test_view_selector',
        componentSelector: '.test_component_selector'
      })

      expect(Vtree.config.viewSelector).toBe('.test_view_selector')
      expect(Vtree.config.componentSelector).toBe('.test_component_selector')
    })
  })
})
