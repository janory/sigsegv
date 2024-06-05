import blurhash from "@mux/blurhash"
import type { ServerLoad } from "@sveltejs/kit"

export const load: ServerLoad = async () => {
  const muxPlaybackId = "3fevCt00ntwf7WxwvBhRo1EZ01IoABwo2d"
  return await blurhash(muxPlaybackId)
}
