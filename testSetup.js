// add all jest-extended matchers
import { toHaveBeenCalledBefore } from 'jest-extended'

expect.extend({ toHaveBeenCalledBefore })
