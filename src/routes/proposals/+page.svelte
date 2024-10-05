<script>
  import { onMount } from 'svelte';
  import { getUserProfile, getJobs } from '$lib/contract';
  import { formatEther, shortenAddress } from '$lib/utils';
  import Button from '$lib/components/Button.svelte';

  let userProposals = [];
  let address = '';

  onMount(async () => {
    if (typeof window !== 'undefined' && window.ethereum) {
      const accounts = await window.ethereum.request({ method: 'eth_requestAccounts' });
      address = accounts[0];
      const profile = await getUserProfile(address);
      const allJobs = await getJobs();

      userProposals = profile
        .filter(item => !item.isEmployer)
        .map(item => {
          const job = allJobs.find(j => j.id.toString() === item.jobId.toString());
          return {
            ...item,
            job: job || { title: 'Unknown Job', budget: '0' }
          };
        });
    }
  });

  function handleViewJob(jobId) {
    window.location.href = `/jobs/${jobId}`;
  }
</script>

<svelte:head>
  <title>JobJam - My Proposals</title>
</svelte:head>

<div class="max-w-4xl mx-auto">
  <h1 class="text-3xl font-bold mb-6">My Proposals</h1>

  {#if userProposals.length === 0}
    <p class="text-gray-600">You haven't submitted any proposals yet.</p>
  {:else}
    <div class="space-y-6">
      {#each userProposals as proposal (proposal.jobId)}
        <div class="bg-white shadow-md rounded-lg p-6">
          <h2 class="text-xl font-semibold mb-2">{proposal.job.title}</h2>
          <p class="text-gray-600 mb-4">Job ID: {proposal.jobId}</p>
          <div class="flex justify-between items-center">
            <span class="text-indigo-600 font-medium">Budget: {formatEther(proposal.job.budget)} ETH</span>
            <span class="text-gray-600">Status: {proposal.isCompleted ? 'Completed' : 'In Progress'}</span>
          </div>
          <div class="mt-4">
            <Button on:click={() => handleViewJob(proposal.jobId)}>View Job Details</Button>
          </div>
        </div>
      {/each}
    </div>
  {/if}
</div>