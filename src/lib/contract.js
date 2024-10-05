import { ethers } from 'ethers';
import { CONTRACT_ADDRESS, RPC_URL } from './config';
import ABI from './abi.json'; //  ABI 

let provider;
let signer;
let contract;

export async function initializeContract() {
  if (typeof window !== 'undefined' && window.ethereum) {
    provider = new ethers.BrowserProvider(window.ethereum);
    signer = await provider.getSigner();
  } else {
    provider = new ethers.JsonRpcProvider(RPC_URL);
  }
  
  contract = new ethers.Contract(CONTRACT_ADDRESS, ABI, signer || provider);
  return contract;
}

export async function getJobs() {
  const contract = await initializeContract();
  const jobCount = await contract.jobIdCounter();
  const jobs = [];

  for (let i = 1; i <= jobCount; i++) {
    const job = await contract.jobs(i);
    if (job.isOpen) {
      jobs.push(job);
    }
  }

  return jobs;
}

export async function createJob(title, description, budget) {
  const contract = await initializeContract();
  const tx = await contract.createJob(title, description, ethers.parseEther(budget.toString()), {
    value: ethers.parseEther(budget.toString())
  });
  await tx.wait();
}

// export async function submitProposal(jobId, description, bid) {
//   const contract = await initializeContract();
//   const tx = await contract.submitProposal(jobId, description, ethers.parseEther(bid.toString()));
//   await tx.wait();
// }
export async function submitProposal(jobId, description, bid) {
    try {
      const contract = await initializeContract();
      const tx = await contract.submitProposal(jobId, description, ethers.parseEther(bid.toString()));
      await tx.wait();
    } catch (error) {
      console.error("Error submitting proposal:", error);
      throw new Error("Failed to submit proposal. Please try again.");
    }
  }

export async function getProposalsForJob(jobId) {
  const contract = await initializeContract();
  return await contract.getProposalsForJob(jobId);
}

export async function acceptProposal(jobId, proposalId) {
  const contract = await initializeContract();
  const tx = await contract.acceptProposal(jobId, proposalId);
  await tx.wait();
}

export async function releasePayment(jobId, proposalId) {
  const contract = await initializeContract();
  const tx = await contract.releasePayment(jobId, proposalId);
  await tx.wait();
}

// export async function getUserProfile(address) {
//   const contract = await initializeContract();
//   return await contract.getUserProfile(address);
// }

export async function getUserProfile(address) {
    const contract = await initializeContract();
    const profileInfo = await contract.getUserProfile(address);
    
    // Fetch additional job details for each job in the profile
    const enhancedProfileInfo = await Promise.all(profileInfo.map(async (job, index) => {
      try {
        const jobId = job.jobId ? job.jobId.toString() : `unknown-${index}`;
        const jobDetails = job.jobId ? await contract.jobs(job.jobId) : null;
        return {
          ...job,
          jobId: jobId,
          title: jobDetails ? jobDetails.title : 'Unknown Job',
          budget: jobDetails ? jobDetails.budget : null,
          isEmployer: job.isEmployer // Ensure this property is correctly passed from the contract
        };
      } catch (error) {
        console.error(`Error fetching details for job:`, error);
        return {
          ...job,
          jobId: `error-${index}`,
          title: 'Error fetching job details',
          budget: null,
          isEmployer: false // Default to false in case of error
        };
      }
    }));
  
    return enhancedProfileInfo;
  }