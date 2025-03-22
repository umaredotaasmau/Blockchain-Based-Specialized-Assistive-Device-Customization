import { describe, it, expect, beforeEach, vi } from 'vitest';

// Mock the Clarity contract interactions
const mockContractCall = vi.fn();
const mockGetDeviceCount = vi.fn();
const mockGetDevice = vi.fn();

// Setup mock responses
beforeEach(() => {
  mockContractCall.mockReset();
  mockGetDeviceCount.mockReset();
  mockGetDevice.mockReset();
  
  // Mock the contract call for registering a device
  mockContractCall.mockImplementation((contractName, functionName, args) => {
    if (contractName === 'device-registration' && functionName === 'register-device') {
      return { success: true, result: { value: 1 } };
    }
    return { success: false, error: 'Unknown function' };
  });
  
  // Mock device count
  mockGetDeviceCount.mockReturnValue(1);
  
  // Mock get device
  mockGetDevice.mockImplementation((deviceId) => {
    if (deviceId === 1) {
      return {
        name: 'Smart Wheelchair',
        manufacturer: 'AccessTech',
        category: 'Mobility',
        'base-features': 'Electric powered, adjustable height',
        'registration-date': 100,
        owner: 'ST1PQHQKV0RJXZFY1DGX8MNSNYVE3VGZJSRTPGZGM'
      };
    }
    return null;
  });
});

// Mock the global object to simulate blockchain environment
global.contractCall = mockContractCall;
global.getDeviceCount = mockGetDeviceCount;
global.getDevice = mockGetDevice;

describe('Device Registration Contract', () => {
  it('should register a new device', async () => {
    const result = await global.contractCall(
        'device-registration',
        'register-device',
        [
          'Smart Wheelchair',
          'AccessTech',
          'Mobility',
          'Electric powered, adjustable height'
        ]
    );
    
    expect(result.success).toBe(true);
    expect(result.result.value).toBe(1);
    expect(mockContractCall).toHaveBeenCalledTimes(1);
  });
  
  it('should get the correct device count', () => {
    const count = global.getDeviceCount();
    expect(count).toBe(1);
    expect(mockGetDeviceCount).toHaveBeenCalledTimes(1);
  });
  
  it('should retrieve a device by ID', () => {
    const device = global.getDevice(1);
    expect(device).not.toBeNull();
    expect(device.name).toBe('Smart Wheelchair');
    expect(device.category).toBe('Mobility');
    expect(mockGetDevice).toHaveBeenCalledTimes(1);
    expect(mockGetDevice).toHaveBeenCalledWith(1);
  });
  
  it('should return null for non-existent device', () => {
    mockGetDevice.mockReturnValueOnce(null);
    const device = global.getDevice(999);
    expect(device).toBeNull();
  });
});
