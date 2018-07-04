func oldcontactfetchfromgroup(fetchedPeopleData:[Contact]){ // inside this we will pass the new data fetched
        //CoreDataHandler.cleanDelete()
        let core = CoreDataHandler.fetchObject()
        print(core?.count as Any)
        for i in core!{
            print("CDdata  ",i.uid!)
        }
        //new people DON'T DELETE VARAIABLE
        var newPeopleData = fetchedPeopleData
        //data DON'T DELETE VARAIABLE
        let oldGroups = GroupCoreDataHandler.fetchObject()
        var allGroup :[String] = []
        
        for oldg in oldGroups!{
            if(allGroup.contains(oldg.groupName!)==false){
                allGroup.append(oldg.groupName!)
            }
        }
        for data in newPeopleData {
            if(allGroup.contains(data.groupName!)==false){
                allGroup.append(data.groupName!)
            }
        }
        
        var newGroupNames:[String] = []
        //var oldContacts:[CNMutableContact] = []
        var oldContacts1:[Peoplenew] = []
        let groups :[CNGroup] = try! store.groups(matching: nil)
        for data in newPeopleData{
            let filteredGroups = groups.filter { $0.name == data.groupName }
            guard let workGroup = filteredGroups.first else {
                print("No Work group")
                newGroupNames.append(data.groupName!)
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
        //        var oldGroupList :[String] = []
        //        for oldGroups in groups{
        //            oldGroupList.append(oldGroups.name)
        //        }
        
        //A Dictionary/Map FOR OLD NAMES
        var oldContactsProtocol = [String:Int]()
        for (indexold,oldContact) in oldContacts1.enumerated(){
            oldContactsProtocol[oldContact.firstName+oldContact.lastName]=indexold
        }
        
        
        for (indexnew,newPerson) in newPeopleData.enumerated() {
            if(oldContactsProtocol.keys.contains(newPerson.firstName!+newPerson.lastName!)){
                let indexold = oldContactsProtocol[newPerson.firstName!+newPerson.lastName!]
                oldContacts1[indexold!].found = "YES"
                newPeopleData[indexnew].found = "YES"
                let oldContact = oldContacts1[indexold!]
                if(oldContact.phoneNo !=  newPerson.phoneNumbers?.main){
                    deleteContactbyuid(data: oldContact.uid)
                    createContact(creationData: newPerson)
                    break
                }
            }
        }
        
        
        //TODO Macthing new people data with old people data
        for (indexnew,newPerson) in newPeopleData.enumerated() {
            for (indexold,oldContact) in oldContacts1.enumerated(){
                if(oldContact.firstName == newPerson.firstName && oldContact.lastName == newPerson.lastName){
                    oldContacts1[indexold].found = "YES"
                    newPeopleData[indexnew].found = "YES"
                    if(oldContact.phoneNo != newPerson.phoneNumbers?.main){
                        deleteContactbyuid(data: oldContact.uid)
                        createContact(creationData: newPerson)
                        break
                    }//checking chnage in data
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
                print("WE are adding a person",peopletoadd.firstName!,peopletoadd.found as Any)
                createContact(creationData: peopletoadd)
            }
        }
        
        for peopletoremove in oldContacts1{
            if(peopletoremove.found == "NO"){
                print("WE are removing a person")
                deleteContactbyuid(data: peopletoremove.uid)
            }
        }
    }
