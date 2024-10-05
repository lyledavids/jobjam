<script>
    import { onMount } from 'svelte';
    import { getJobs, getMyJobs } from '$lib/contract';
    import JobCard from '$lib/components/JobCard.svelte';
  
    let jobs = [];
    let myJobs = [];
    let address = '';
  
    onMount(async () => {
        if (typeof window !== 'undefined' && window.ethereum) {
            const accounts = await window.ethereum.request({ method: 'eth_requestAccounts' });
            address = accounts[0];
            jobs = await getJobs();
            myJobs = await getMyJobs(address);
        }
      
    });
  </script>
  
  <svelte:head>
    <title>JobJam - All Jobs</title>
  </svelte:head>

  {#if myJobs.length > 0}
    <h1 class="text-3xl font-bold mb-6">Jobs created by me</h1>
    {#each jobs as job (job.id)}
        <JobCard {job} />
    {/each}
  {/if}
  
  <h1 class="text-3xl font-bold mb-6">All Jobs</h1>
  
  <div class="grid gap-6 md:grid-cols-2 lg:grid-cols-3">
    {#each jobs as job (job.id)}
      <JobCard {job} />
    {/each}
  </div>