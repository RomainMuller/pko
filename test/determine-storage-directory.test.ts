import fs = require('fs-extra');
import os = require('os');
import { determineStorageDirectory } from '../lib/determine-storage-directory';

describe('determineStorageDirectory', () => {
  test('when $PKO_REPOSITORY is defined', async () => {
    const expected = await fs.mkdtemp(os.tmpdir());
    try {
      process.env.PKO_REPOSITORY = expected;
      return await expect(determineStorageDirectory()).resolves.toBe(expected);
    } finally {
      await fs.remove(expected);
      delete process.env.PKO_REPOSITORY;
    }
  });
});
