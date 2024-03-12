<script lang="ts">
  import type { PageData } from "./$types"

  export let data: PageData
</script>

<img src={data.blurHashBase64} />
