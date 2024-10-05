<script>
    import '../app.css';
    import Navbar from '$lib/components/Navbar.svelte';
  </script>
  
  <Navbar />
  
  <main class="max-w-7xl mx-auto py-6 sm:px-6 lg:px-8">
    <slot />
  </main>