//
//  Interfaces.swift
//  JukuFlashCard
//
//  Created by System Administrator on 5/27/17.
//  Copyright © 2017 jukuproject. All rights reserved.
//

import UIKit

/**
 Liason between BrowseItemsMyLists_CutCopy dialog and BrowseItems_MyLists, so MyList VC is updated
 when words are moved/copied between lists
 */
protocol  CutCopyReloadDataDelegate {
    func removeidsandreload(selectedRowstoRemove : [Int : Int])  -> Void
    func cancelPressed() -> Void
    func reloadMainMyListController() -> Void
}


/**
 Liason between MyListChooserPopover and Search VC, updating the table/entryset in Search when uesr
 chooses new word lists to attach a given word to
 */
protocol MyListChooserPopoverDelegate: class
{
    func retrieveUpdatedFavoritesFromMyListChooser(updatedFavorites: StarColorData, rowIndexPath: NSIndexPath?)
    func dismissMyListChooserPopover();
}


/**
 Interface between Sub-activities (BrowseItems_MyLists, FlashCards) and the main menu container (ContainerMainView),
 so that the custom navbar can display propper titles and menu buttons depending on the current VC
 */
protocol ContainerMainView_ChangeNavBarDelegate
{
    func setthecutcopyitems_mainview() -> Void;
    func showthecutcopyitems_mainview(show : Bool)
    func poptheview() -> Void;
    func changeNavBarButton_SetBackButton(title : String)
    func changeNavBarButtons_SetMain()
    func reloadmainlistcontroller()  -> Void;
}

/**
 Interface between DraggableView (a single "card" in the FlashCards VC) and DraggableViewBackground, which
 controls how the stack of flashcard views is managed
 */
protocol DraggableViewDelegate {
    func cardSwipedForward(card: UIView) -> Void
    func cardSwipedBackward(card: UIView) -> Void
    func isThereAnotherCardBelow() -> Bool
    func nextcardalreadycreated() -> Bool
    func undonextcard(card: UIView, fromabove : Bool) -> Void
    func setnextcardtofalse() -> Void
    func setconstraints(draggableView: DraggableView,isdefinition: Bool)
}


/**
 Interface between the MyList Editing/Creating popovers and the ListController_MyLists VC
 */
protocol CreateAListDelegate {
    func createthenewlist(newlistname: String) -> Void
    func clearordeletethelist(name: String, sys : Int, delete : Bool)
    func renamethelist(oldname: String, newname : String)
    func showCreateListPopover(renamelist: Bool, oldname: String)
    
}

/**
 Interface between MenuPopover_FlashCards popover and the ListController_MyLists VC
 */
protocol MenuPopoverFlashCardsDelegate: class
{
    func seguetoactivity(package: MenuPopoverToSeguePackage);
}

/**
 Interface between browseitems custom cell and the Search VC, so the Search activity can
 be updated when the favorites star is clicked inside a row of the search result set
 */
protocol customCell_ListChooserDelegate: class
{
    func retrieveUpdatedFavorites(dataSetIndex: Int, updatedFavorites: StarColorData)
    func tellNavContoUpdateMainViews(changeit: Bool);
    func showListChooserPopover(wordEntry : WordEntry,starOrigin: CGPoint!, availableWordLists: StarColorData,rowIndexPath: NSIndexPath  );
}

