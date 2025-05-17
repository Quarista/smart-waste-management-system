
export type ModelType = "basic" | "smart";

export interface ModelConfig {
  modelName: string;
  displayName: string;
  description: string;
}

export const MODEL_CONFIGS: Record<ModelType, ModelConfig> = {
  basic: {
    modelName: "Duster V1.0 - 3B-Instruct-q4f16_1-MLC",
    displayName: "Basic AI model | Stable",
    description: "Integrated with MLC and Gemini 1.5 Flash Model",
  },
  smart: {
    modelName: "Duster V1.2 - 3.2-3B-Instruct-q4f16_1-MLC", 
    displayName: "Alpha AI model | Unstable",
    description: "Development with MLC and Gemini 1.5 Pro Model",
  }
};