<template>
  <div class="rounded-xl px-2 p-4 bg-green-200 dark:bg-[#0f141b] my-4 text-green-800 dark:text-green-200">
    <!-- https://content.nuxtjs.org/api/components/content-slot -->
    <ContentSlot :use="$slots.default" unwrap="p" />
  </div>
</template>

<style>
@media (prefers-color-scheme: light) {
  ::selection {
    background-color: #f81ce5;
  }
}
@media (prefers-color-scheme: dark) {
  ::selection {
    background-color: #f81ce5;
  }
}
</style>
