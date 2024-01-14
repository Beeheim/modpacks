const axios = require('axios');
const rateLimit = require('axios-rate-limit');
const fetchIndex = require('./parseDependencies.js');
const fs = require('fs');

const expectedIndexDataPath = './test/expectedData.txt';

const expectedIndexDataString = fs.readFileSync(expectedIndexDataPath, 'utf8');


// Mock axiosInstance for testing
jest.mock('axios-rate-limit');
const axiosInstance = rateLimit(axios.create(), { maxRequests: 1, perMilliseconds: 1000 });
jest.spyOn(axios, 'create').mockReturnValue(axiosInstance);

describe('fetchIndex', () => {
  afterEach(() => {
    jest.clearAllMocks();
  });

  it('should fetch the index from the specified URL', async () => {
    const url = 'https://example.com/index.json';
    const expectedData = expectedIndexDataString;

    axiosInstance.get.mockResolvedValueOnce({ data: expectedData });

    const result = await fetchIndex(url);

    expect(axiosInstance.get).toHaveBeenCalledWith(url, {
      headers: {
        'Accept-Encoding': 'gzip'
      }
    });
    expect(result).toEqual(expectedData);
  });

  it('should handle parsing errors and filter out invalid entries', async () => {
    const url = 'https://example.com/index.json';
    const responseData = 'entry1\ninvalidJSON\nentry2';
    const expectedData = ['entry1', 'entry2'];

    axiosInstance.get.mockResolvedValueOnce({ data: responseData });

    const result = await fetchIndex(url);

    expect(axiosInstance.get).toHaveBeenCalledWith(url, {
      headers: {
        'Accept-Encoding': 'gzip'
      }
    });
    expect(result).toEqual(expectedData);
    expect(console.error).toHaveBeenCalledWith('Failed to parse JSON: invalidJSON');
  });

  it('should return null on error', async () => {
    const url = 'https://example.com/index.json';
    const error = new Error('Network request failed');

    axiosInstance.get.mockRejectedValueOnce(error);

    const result = await fetchIndex(url);

    expect(axiosInstance.get).toHaveBeenCalledWith(url, {
      headers: {
        'Accept-Encoding': 'gzip'
      }
    });
    expect(result).toBeNull();
    expect(console.error).toHaveBeenCalledWith(error);
  });
});