<script>
    export let type = 'button';
    export let disabled = false;
  </script>
  
  <button
    {type}
    {disabled}
    class="bg-indigo-600 text-white px-4 py-2 rounded-md text-sm font-medium hover:bg-indigo-700 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-indigo-500"
    on:click
  >
    <slot></slot>
  </button>