<script>
    import { createJob } from '$lib/contract';
    import Button from '$lib/components/Button.svelte';
  
    let title = '';
    let description = '';
    let budget = '';
  
    async function handleSubmit() {
      await createJob(title, description, budget);
      title = '';
      description = '';
      budget = '';
      alert('Job created successfully!');
    }
  </script>
  
  <svelte:head>
    <title>JobJam - Create Job</title>
  </svelte:head>
  
  <h1 class="text-3xl font-bold mb-6">Create a New Job</h1>
  
  <form on:submit|preventDefault={handleSubmit} class="max-w-lg">
    <div class="mb-4">
      <label for="title" class="block text-sm font-medium text-gray-700">Title</label>
      <input type="text" id="title" bind:value={title} required class="mt-1 block w-full border-gray-300 rounded-md shadow-sm focus:ring-indigo-500 focus:border-indigo-500 sm:text-sm">
    </div>
  
    <div class="mb-4">
      <label for="description" class="block text-sm font-medium text-gray-700">Description</label>
      <textarea id="description" bind:value={description} required class="mt-1 block w-full border-gray-300 rounded-md shadow-sm focus:ring-indigo-500 focus:border-indigo-500 sm:text-sm"></textarea>
    </div>
  
    <div class="mb-4">
      <label for="budget" class="block text-sm font-medium text-gray-700">Budget - KLAY(KAIA)</label>
      <input type="number" id="budget" bind:value={budget} required step="0.01" min="0" class="mt-1 block w-full border-gray-300 rounded-md shadow-sm focus:ring-indigo-500 focus:border-indigo-500 sm:text-sm">
    </div>
  
    <Button type="submit">Create Job</Button>
  </form>