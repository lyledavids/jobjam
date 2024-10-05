<script>
    import { onMount } from 'svelte';
    import { getSigner } from '$lib/ethers-utils.js';
    import { getUserProposals } from '$lib/contract-utils.js';
  
    let proposals = [];
  
    onMount(async () => {
      const signer = getSigner();
      const address = await signer.getAddress();
      proposals = await getUserProposals(address);
    });
  </script>
  
  <h1 class="text-3xl font-bold mb-6">My Proposals</h1>
  
  <div class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">
    {#each proposals as proposal (proposal.id)}
      <div class="bg-white shadow-md rounded-lg p-6">
        <h2 class="text-xl font-semibold mb-2">{proposal.jobTitle}</h2>
        <p class="text-gray-600 mb-2">{proposal.description}</p>
        <div class="flex justify-between items-center">
          <span class="text-blue-600 font-bold">{proposal.bid} KLAY(KAIA)</span>
          <span class={proposal.isAccepted ? 'text-green-500' : 'text-yellow-500'}>
            {proposal.isAccepted ? 'Accepted' : 'Pending'}
          </span>
        </div>
        <a href={`/job/${proposal.jobId}`} class="mt-4 inline-block bg-blue-500 text-white px-4 py-2 rounded hover:bg-blue-600">View Job</a>
      </div>
    {/each}
  </div>
  
  {#if proposals.length === 0}
    <p class="text-gray-600">You haven't submitted any proposals yet.</p>
  {/if}