<script>
    import { page } from '$app/stores';
    import { onMount } from 'svelte';
    import { shortenAddress } from '$lib/utils';
  
    let address = '';
  
    onMount(async () => {
      if (typeof window !== 'undefined' && window.ethereum) {
        const accounts = await window.ethereum.request({ method: 'eth_requestAccounts' });
        address = accounts[0];
      }
    });
  </script>
  
  <nav class="bg-white shadow-lg">
    <div class="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
      <div class="flex justify-between h-16">
        <div class="flex">
          <div class="flex-shrink-0 flex items-center">
            <a href="/" class="text-xl font-bold text-indigo-600">JobJam</a>
          </div>
          <div class="hidden sm:ml-6 sm:flex sm:space-x-8">
            <a href="/" class="border-indigo-500 text-gray-900 inline-flex items-center px-1 pt-1 border-b-2 text-sm font-medium" class:border-indigo-500={$page.url.pathname === '/'}>Home</a>
            <a href="/jobs" class="border-transparent text-gray-500 hover:border-gray-300 hover:text-gray-700 inline-flex items-center px-1 pt-1 border-b-2 text-sm font-medium" class:border-indigo-500={$page.url.pathname === '/jobs'}>Jobs</a>
            <a href="/create-job" class="border-transparent text-gray-500 hover:border-gray-300 hover:text-gray-700 inline-flex items-center px-1 pt-1 border-b-2 text-sm font-medium" class:border-indigo-500={$page.url.pathname === '/create-job'}>Create Job</a>
            <a href="/profile" class="border-transparent text-gray-500 hover:border-gray-300 hover:text-gray-700 inline-flex items-center px-1 pt-1 border-b-2 text-sm font-medium" class:border-indigo-500={$page.url.pathname === '/profile'}>Profile</a>
          </div>
        </div>
        <div class="hidden sm:ml-6 sm:flex sm:items-center">
          {#if address}
            <span class="text-sm font-medium text-gray-500">{shortenAddress(address)}</span>
          {:else}
            <button class="bg-indigo-600 text-white px-4 py-2 rounded-md text-sm font-medium" on:click={() => window.ethereum.request({ method: 'eth_requestAccounts' })}>Connect Wallet</button>
          {/if}
        </div>
      </div>
    </div>
  </nav>