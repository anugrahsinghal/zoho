func oldcontactfetchfromgroup1(fetchedPeopleData:[Contact]){ // inside this we will pass the new data fetched
        //        CoreDataHandler.cleanDelete()
        //        GroupCoreDataHandler.cleanDelete()
        
        let core = CoreDataHandler.fetchObject()
        print(core?.count as Any)
        for i in core!{
            print("CDdata  ",i.uid!)
        }
        hjgehrfhk
        //new people DON'T DELETE VARAIABLE
        var newPeopleData = fetchedPeopleData
        //data DON'T DELETE VARAIABLE
        let oldGroups = GroupCoreDataHandler.fetchObject()
        var allGroup :[String] = []
        
        for oldg in oldGroups!{
            print(oldg.groupName as Any,oldg.guid as Any)
            if(allGroup.contains(oldg.groupName!)==false){
                allGroup.append(oldg.groupName!)
            }
        }
        for data in newPeopleData {
            if(allGroup.contains(data.groupName!)==false){
                allGroup.append(data.groupName!)
            }
        }
        
        var groupsToDelete :[String] = []
        //        var oldgnam:[String] = []
        var flag = 0
        for oldg in oldGroups!{
            flag=0
            for data in newPeopleData {
                if(oldg.groupName == data.groupName){
                    flag=1
                    break
                }
            }
            if(flag==0){
                groupsToDelete.append(oldg.groupName!)
            }
        }
        
        print("Groups to delete ",groupsToDelete)
        
        var newGroupNames:[String] = []
        //var oldContacts:[CNMutableContact] = []
        var oldContacts1:[Peoplenew] = []
        let groups :[CNGroup] = try! store.groups(matching: nil)
        for data in allGroup{
            let filteredGroups = groups.filter { $0.name == data }
            guard let workGroup = filteredGroups.first else {
                print("No Work group")
                newGroupNames.append(data)
                return
            }
            let predicate = CNContact.predicateForContactsInGroup(withIdentifier: workGroup.identifier)
            let keysToFetch = [CNContactGivenNameKey,CNContactFamilyNameKey,CNContactPhoneNumbersKey,CNContactIdentifierKey] as [CNKeyDescriptor]
            let contacts = try! store.unifiedContacts(matching: predicate, keysToFetch: keysToFetch)
            for oldcontact in contacts{
                //oldContacts.append(oldcontact.mutableCopy() as! CNMutableContact)
                oldContacts1.append(Peoplenew(uid:oldcontact.identifier,firstName: oldcontact.givenName, lastName: oldcontact.familyName, phoneNo: oldcontact.phoneNumbers.first?.value.stringValue, companyName: "", found: "NO"))
            }//append all the old contact that were in that group
        }//for loop ends for each group
        //so finally this will contain all the old contact in all the groups
        
        //create all new groups that were found in api
        for newGroup in newGroupNames{
            addNewGroup(name: newGroup)
        }
        
        //A Dictionary/Map FOR OLD NAMES
        var oldContactDictionary = [String:Int]()
        for (indexold,oldContact) in oldContacts1.enumerated(){
            oldContactDictionary[oldContact.firstName+oldContact.lastName]=indexold
        }
        
        
        for (indexnew,newPerson) in newPeopleData.enumerated() {
            if(oldContactDictionary.keys.contains(newPerson.firstName!+newPerson.lastName!)){
                let indexold = oldContactDictionary[newPerson.firstName!+newPerson.lastName!]
                oldContacts1[indexold!].found = "YES"
                newPeopleData[indexnew].found = "YES"
                let oldContact = oldContacts1[indexold!]
                if(oldContact.phoneNo != newPerson.phoneNumbers?.main){
                    deleteContactbyuid(data: oldContact.uid)
                    createContact(creationData: newPerson)
                }
            }
        }
        
        for p in newPeopleData{
            print(p.firstName!,p.found as Any)
        }
        
        for p in oldContacts1{
            print(p.firstName,p.found as Any)
        }
        
        for peopletoadd in newPeopleData{
            if(peopletoadd.found == "NO"){
                print("WE are adding a person",peopletoadd.firstName as Any,peopletoadd.found as Any)
                createContact(creationData: peopletoadd)
            }
        }
        
        for peopletoremove in oldContacts1{
            if(peopletoremove.found == "NO"){
                print("WE are removing a person")
                deleteContactbyuid(data: peopletoremove.uid)
            }
        }
        
        for deleteGroups in groupsToDelete{
            removeGroup(groupName: deleteGroups)
        }
        
    }
