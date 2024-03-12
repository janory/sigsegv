import blurhash from "@mux/blurhash"
import type { ServerLoad } from "@sveltejs/kit"

export const load: ServerLoad = async () => {
  const muxPlaybackId = "svvqOj01YsD02Hkhd0267CAB1B02GoeL4eS2TsJ4cN1vlwk"
  return await blurhash(muxPlaybackId)
}
