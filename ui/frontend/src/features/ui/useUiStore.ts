import { create } from "zustand";

type UiState = {
  locale: "ru" | "en";
  setLocale: (locale: "ru" | "en") => void;
};

export const useUiStore = create<UiState>((set) => ({
  locale: "ru",
  setLocale: (locale) => set({ locale }),
}));
