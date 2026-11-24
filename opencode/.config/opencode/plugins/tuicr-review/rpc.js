import { Rpc } from "@opencode/plugin/rpc"

const request = {
  type: "object",
  properties: {
    requestID: { type: "string" },
    sessionID: { type: "string" },
    args: { type: "array", items: { type: "string" } },
    summary: { type: "string" },
  },
  required: ["requestID", "sessionID", "args", "summary"],
  additionalProperties: false,
}

export const TuicrReview = Rpc.define({
  id: "tuicr-review",
  methods: {
    pending: {
      input: {},
      output: {
        type: "object",
        properties: { requests: { type: "array", items: request } },
        required: ["requests"],
        additionalProperties: false,
      },
    },
    answer: {
      input: {
        type: "object",
        properties: {
          requestID: { type: "string" },
          decision: { enum: ["open", "not-now", "auto-accept"] },
          rexSession: { type: "string" },
        },
        required: ["requestID", "decision"],
        additionalProperties: false,
      },
      output: {
        type: "object",
        properties: { accepted: { type: "boolean" } },
        required: ["accepted"],
        additionalProperties: false,
      },
    },
  },
  events: {
    requested: { schema: request },
    settled: {
      schema: {
        type: "object",
        properties: { requestID: { type: "string" }, sessionID: { type: "string" } },
        required: ["requestID", "sessionID"],
        additionalProperties: false,
      },
    },
  },
})
