<script>
    import { onMount } from 'svelte';
    import { getUserProfile } from '$lib/contract';
    import { shortenAddress, formatEther } from '$lib/utils';
  
    let userProfile = [];
    let address = '';
  
    onMount(async () => {
      if (typeof window !== 'undefined' && window.ethereum) {
        const accounts = await window.ethereum.request({ method: 'eth_requestAccounts' });
        address = accounts[0];
        userProfile = await getUserProfile(address);
      }
    });
  </script>
  
  <svelte:head>
    <title>JobJam - User Profile</title>
  </svelte:head>
  
  <h1 class="text-3xl font-bold mb-6">User Profile</h1>
  
  <p class="mb-4">Address: {shortenAddress(address)}</p>
  
  <h2 class="text-2xl font-semibold mb-4">Job History</h2>
  
  <div class="grid gap-4">
    {#each userProfile as job (job.jobId)}
      <div class="bg-white shadow-md rounded-lg p-4">
        <h3 class="text-lg font-semibold mb-2">{job.title}</h3>
        <p>Job ID: {job.jobId}</p>
        <p>Role: {job.isEmployer ? 'Employer' : 'Freelancer'}</p>
        <p>Status: {job.isCompleted ? 'Completed' : 'In Progress'}</p>
        <p>Budget: {job.budget ? formatEther(job.budget) : 'N/A'} KLAY(KAIA)</p>
      </div>
    {/each}
  </div>