import { computed, reactive, ref, type Ref } from "vue";
import {
  createGlobalState,
  createSharedComposable,
  useLocalStorage,
  useSessionStorage,
} from "@vueuse/core";
import type { UserSnapshot } from "@onflow/fcl";

// ---------------- Global State ----------------

export const useTheme = createGlobalState(() =>
  useLocalStorage("theme", "light")
);

export const useGlobalAccount = createGlobalState(() =>
  useSessionStorage("x-app-account", "")
);

export const useCurrentFlowUser = createGlobalState(
  (): Ref<UserSnapshot | null> => {
    return ref(null);
  }
);

export const useNetworkCorrect = createGlobalState(() => {
  return ref(false);
});

export const useSendingTransaction = createGlobalState(() => {
  return ref(false);
});

// ---------------- Composables ----------------

const flowUser = useCurrentFlowUser();
const acctName = useGlobalAccount();
const isNetworkCorrect = useNetworkCorrect();

export const useCurrentSignerAddress = createSharedComposable(() => {
  return computed<string | undefined>(() => {
    if (flowUser.value && flowUser.value.addr) {
      return flowUser.value.addr;
    } else {
      return undefined;
    }
  });
});

export const useIsConnected = createSharedComposable(() => {
  return computed<boolean>(() => {
    return !!acctName.value && isNetworkCorrect.value;
  });
});

// ---------------- Functions ----------------

/**
 * Update the global account address
 */
export function updateGlobalAccount(addr?: string) {
  if (typeof addr === "string" && addr) {
    acctName.value = addr;
  } else {
    acctName.value = null;
  }
}

// ---------------- Constants ----------------
