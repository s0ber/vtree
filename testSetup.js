// add all jest-extended matchers
import { toHaveBeenCalledBefore, toHaveBeenCalledOnce } from 'jest-extended'

expect.extend({
  toHaveBeenCalledBefore,
  toHaveBeenCalledOnce
})
