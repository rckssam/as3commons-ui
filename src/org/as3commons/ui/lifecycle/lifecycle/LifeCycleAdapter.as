package org.as3commons.ui.lifecycle.lifecycle {

	import org.as3commons.collections.LinkedSet;
	import org.as3commons.collections.Set;
	import org.as3commons.collections.framework.IIterator;
	import org.as3commons.collections.framework.IOrderedSet;
	import org.as3commons.collections.framework.ISet;
	import org.as3commons.ui.framework.core.as3commons_ui;
	import org.as3commons.ui.lifecycle.i10n.Invalidation;

	import flash.display.DisplayObject;

	/**
	 * <code>LifeCycle</code> basic component adapter.
	 * 
	 * @author Jens Struwe 25.05.2011
	 */
	public class LifeCycleAdapter implements ILifeCycleAdapter {
		
		/**
		 * Callback for the init event.
		 */
		protected var _initHandler : Function;

		/**
		 * Callback for the prepare update event.
		 */
		protected var _prepareUpdateHandler : Function;

		/**
		 * Callback for the update event.
		 */
		protected var _updateHandler : Function;

		/**
		 * Callback for the clean up event.
		 */
		protected var _cleanUpHandler : Function;

		/**
		 * Internal Invalidation instance.
		 */
		protected var _i10n : Invalidation;

		/**
		 * Display object to manage by this adapter.
		 */
		protected var _component : DisplayObject;

		/**
		 * List of components to be updated beforehand.
		 */
		protected var _autoUpdates : IOrderedSet;

		/**
		 * List of invalid properties.
		 */
		protected var _invalidProperties : ISet;

		/**
		 * List of update kinds.
		 */
		protected var _updateKinds : ISet;

		/**
		 * Flag to decide if init or update is to perform.
		 */
		protected var _initialized : Boolean;

		/**
		 * <code>LifeCycleAdapter</code> constructor.
		 */
		public function LifeCycleAdapter() {
			_autoUpdates = new LinkedSet();
			_updateKinds = new Set();
		}
		
		/*
		 * ILifeCycleAdaper
		 */

		/**
		 * @inheritDoc
		 */
		public function get component() : DisplayObject {
			return _component;
		}
		
		/**
		 * @inheritDoc
		 */
		public function autoUpdateBefore(child : DisplayObject) : void {
			_autoUpdates.add(child);
		}

		/**
		 * @inheritDoc
		 */
		public function removeAutoUpdateBefore(child : DisplayObject) : void {
			_autoUpdates.remove(child);
		}

		/**
		 * @inheritDoc
		 */
		public function invalidate(property : String = null) : void {
			_i10n.invalidate(_component, property);
		}

		/**
		 * @inheritDoc
		 */
		public function validateNow() : void {
			_i10n.validateNow(_component);
		}
		
		/**
		 * @inheritDoc
		 */
		public function isInvalid(property : String) : Boolean {
			if (!_invalidProperties) return false;
			if (_invalidProperties.has(Invalidation.ALL_PROPERTIES)) return true;
			return _invalidProperties.has(property);
		}

		/**
		 * @inheritDoc
		 */
		public function scheduleUpdate(updateKind : String) : void {
			_updateKinds.add(updateKind);
		}
		
		/**
		 * @inheritDoc
		 */
		public function shouldUpdate(updateKind : String) : Boolean {
			return _updateKinds.has(updateKind);
		}

		/**
		 * @inheritDoc
		 */
		public function cleanUp() : void {
			_i10n.stopValidation(_component);

			if (_cleanUpHandler != null) {
				_cleanUpHandler(this);
			} else {
				onCleanUp();
			}
		}

		/**
		 * @inheritDoc
		 */
		public function set initHandler(initHandler : Function) : void {
			_initHandler = initHandler;
		}

		/**
		 * @inheritDoc
		 */
		public function set prepareUpdateHandler(prepareUpdateHandler : Function) : void {
			_prepareUpdateHandler = prepareUpdateHandler;
		}

		/**
		 * @inheritDoc
		 */
		public function set updateHandler(updateHandler : Function) : void {
			_updateHandler = updateHandler;
		}

		/**
		 * @inheritDoc
		 */
		public function set cleanUpHandler(cleanUpHandler : Function) : void {
			_cleanUpHandler = cleanUpHandler;
		}

		/*
		 * Internal
		 */

		/**
		 * Framework internal method to set up a component.
		 * 
		 * @param i10n <code>Invalidation</code> reference.
		 * @return component The component using this adapter.
		 */
		as3commons_ui function setUp_internal(i10n : Invalidation, component : DisplayObject) : void {
			_i10n = i10n;
			_component = component;
			i10n.invalidate(_component);
		}

		/**
		 * Framework internal callback for the <code>Invalidation</code> will validate event.
		 */
		as3commons_ui function willValidate_internal() : void {
			if (!_initialized) return;
			
			var iterator : IIterator = _autoUpdates.iterator();
			while (iterator.hasNext()) {
				_i10n.validateNow(iterator.next());
			}
		}

		/**
		 * Framework internal callback for the <code>Invalidation</code> validate event.
		 */
		as3commons_ui function validate_internal(invalidProperties : ISet) : void {
			if (_initialized) {
				// prepare update
				_invalidProperties = invalidProperties;
				if (_prepareUpdateHandler != null) {
					_prepareUpdateHandler(this);
				} else {
					onPrepareUpdate();
				}
				
				// execute update
				if (_updateHandler != null) {
					_updateHandler(this);
				} else {
					onUpdate();
				}

				// cleanup
				_updateKinds.clear();
				_invalidProperties.clear();
				
			} else {
				if (_initHandler != null) {
					_initHandler(this);
				} else {
					onInit();
				}
				_initialized = true;
			}
		}

		/*
		 * Protected
		 */

		/**
		 * Default init hook.
		 */
		protected function onInit() : void {
		}

		/**
		 * Default pre update hook.
		 */
		protected function onPrepareUpdate() : void {
		}

		/**
		 * Default update hook.
		 */
		protected function onUpdate() : void {
		}

		/**
		 * Default clean up hook.
		 */
		protected function onCleanUp() : void {
		}

	}
}
