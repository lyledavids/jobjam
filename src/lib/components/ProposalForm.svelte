<script>
    import { createEventDispatcher } from 'svelte';
    import { submitProposal } from '$lib/contract';
    import Button from './Button.svelte';
  
    export let jobId;
  
    let description = '';
    let bid = '';
    let isSubmitting = false;
    let error = null;
  
    const dispatch = createEventDispatcher();
  
    async function handleSubmit() {
      isSubmitting = true;
      error = null;
  
      try {
        await submitProposal(jobId, description, bid);
        dispatch('proposalSubmitted');
        description = '';
        bid = '';
      } catch (err) {
        error = err.message;
      } finally {
        isSubmitting = false;
      }
    }
  </script>
  
  <form on:submit|preventDefault={handleSubmit} class="bg-white shadow-md rounded-lg p-6 mb-4">
    <h3 class="text-xl font-semibold mb-4">Submit a Proposal</h3>
    
    <div class="mb-4">
      <label for="description" class="block text-sm font-medium text-gray-700">Description</label>
      <textarea
        id="description"
        bind:value={description}
        required
        class="mt-1 block w-full px-3 py-2 bg-white border border-gray-300 rounded-md shadow-sm focus:outline-none focus:ring-indigo-500 focus:border-indigo-500 sm:text-sm"
      ></textarea>
    </div>
  
    <div class="mb-4">
      <label for="bid" class="block text-sm font-medium text-gray-700">Bid (ETH)</label>
      <input
        type="number"
        id="bid"
        bind:value={bid}
        required
        step="0.01"
        min="0"
        class="mt-1 block w-full px-3 py-2 bg-white border border-gray-300 rounded-md shadow-sm focus:outline-none focus:ring-indigo-500 focus:border-indigo-500 sm:text-sm"
      />
    </div>
  
    <Button type="submit" disabled={isSubmitting}>
      {isSubmitting ? 'Submitting...' : 'Submit Proposal'}
    </Button>
  
    {#if error}
      <p class="mt-2 text-red-600">{error}</p>
    {/if}
  </form>