<script>
    import { formatEther, shortenAddress } from '$lib/utils';
    export let proposal;
    export let onAccept;
    export let showAcceptButton = false;
  </script>
  
  <div class="bg-white shadow-md rounded-lg p-6 mb-4">
    <h3 class="text-lg font-semibold mb-2">Proposal from {shortenAddress(proposal.freelancer)}</h3>
    <p class="text-gray-600 mb-4">{proposal.description}</p>
    <div class="flex justify-between items-center">
      <span class="text-indigo-600 font-medium">Bid: {formatEther(proposal.bid)} KLAY(KAIA)</span>
      {#if showAcceptButton && !proposal.isAccepted}
        <button on:click={() => onAccept(proposal.id)} class="bg-indigo-600 text-white px-4 py-2 rounded-md text-sm font-medium">Accept Proposal</button>
      {:else if proposal.isAccepted}
        <span class="text-green-600 font-medium">Accepted</span>
      {/if}
    </div>
  </div>