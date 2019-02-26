//
// (c) 2016 Appirio, Inc.
//
// Class Name: DuplicateIdentifierQueueable
// Description: Queueable job used to identify and mark duplicate optionals
//
public class DuplicateIdentifierQueueable implements Queueable
{

	Set<String> uniqueOptionalCodes;
	List<Optional__c> optionals, potentialDuplicates, recordsToUpdate;
	Map<String, List<Optional__c>> uniqueOptionalCodeMap;

	public DuplicateIdentifierQueueable(List<Optional__c> optionals)
	{
		this.optionals = optionals;
	}

	public void execute(QueueableContext context)
	{
		initializeVariables();
		addUniqueCodesToSet();
		queryExistingOptionals();
		addPotentialDuplicatesToMap();
		if(findDuplicates())
			updateDuplicateOptionals();
	}

	private void initializeVariables()
	{
		uniqueOptionalCodes = new Set<String>();
		uniqueOptionalCodeMap = new Map<String, List<Optional__c>>();
		potentialDuplicates = new List<Optional__c>();
		recordsToUpdate = new List<Optional__c>();
	}

	private void addUniqueCodesToSet()
	{
		for (Optional__c opt : optionals)
		{
			if (opt.Optional_Unique_Code__c != '-')
				uniqueOptionalCodes.add(opt.Optional_Unique_Code__c);
		}
	}

	private void queryExistingOptionals()
	{
		potentialDuplicates = [SELECT Optional_Unique_Code__c, Day__c, CreatedDate
							  FROM Optional__c
							  WHERE Optional_Unique_Code__c IN: uniqueOptionalCodes];
	}

	private void addPotentialDuplicatesToMap()
	{
		for (Optional__c opt : potentialDuplicates)
		{
			if (!uniqueOptionalCodeMap.containsKey(opt.Optional_Unique_Code__c))
				uniqueOptionalCodeMap.put(opt.Optional_Unique_Code__c, new List<Optional__c>{opt});
			else
				uniqueOptionalCodeMap.get(opt.Optional_Unique_Code__c).add(opt);
		}
	}

	private Boolean findDuplicates()
	{
		boolean duplicatesFound = false;
		for (String uniqueOptionalCode : uniqueOptionalCodeMap.keySet())
		{
			List<Optional__c> optionalsForUniqueCode = uniqueOptionalCodeMap.get(uniqueOptionalCode);
			if (optionalsForUniqueCode.size() > 1)
			{
				markDuplicates(optionalsForUniqueCode);
				duplicatesFound = true;
			}
		}
		return duplicatesFound;
	}


	private void markDuplicates(List<Optional__c> optionalsForUniqueCode)
	{
		Optional__c nonDuplicateOptional = optionalsForUniqueCode[0];
		nonDuplicateOptional.Duplicate__c = false;
		for (Optional__c opt : optionalsForUniqueCode)
		{
			recordsToUpdate.add(opt);
			if (opt == nonDuplicateOptional)
				continue;

			if (nonDuplicateOptional.Day__c > opt.Day__c)
			{
				nonDuplicateOptional.Duplicate__c = true;
				opt.Duplicate__c = false;
				nonDuplicateOptional = opt;
			}

			else if (nonDuplicateOptional.Day__c == opt.Day__c)
			{
				if (nonDuplicateOptional.CreatedDate < opt.CreatedDate)
				{
					opt.Duplicate__c = true;
				}
				else
				{
					nonDuplicateOptional.Duplicate__c = true;
					opt.Duplicate__c = false;
					nonDuplicateOptional = opt;
				}
			}
			else
			{
				opt.Duplicate__c = true;
			}
		}
	}

	private void updateDuplicateOptionals()
	{
		update recordsToUpdate;
	}
}